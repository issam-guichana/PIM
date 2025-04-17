import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';

class AnomalyChartScreen extends StatefulWidget {
  const AnomalyChartScreen({super.key});

  @override
  State<AnomalyChartScreen> createState() => _AnomalyChartScreenState();
}

class _AnomalyChartScreenState extends State<AnomalyChartScreen> {
  List<FlSpot> normalPoints = [];
  List<FlSpot> anomalyPoints = [];
  bool errorLoading = false;

  @override
  void initState() {
    super.initState();
    loadCsvData();
  }

  Future<void> loadCsvData() async {
    debugPrint("📂 Chargement du fichier CSV..."); // LOG:

    try {
      final rawData = await rootBundle.loadString('Assets/anomaliesdetectedv2.csv');

      if (rawData.trim().isEmpty) {
        debugPrint("❌ Fichier CSV vide."); // LOG:
        setState(() => errorLoading = true);
        return;
      }

      List<List<dynamic>> csvTable = const CsvToListConverter().convert(rawData);
      if (csvTable.isEmpty || csvTable[0].length < 7) {
        debugPrint("❌ Format du CSV invalide."); // LOG:
        setState(() => errorLoading = true);
        return;
      }

      final rows = csvTable.sublist(1);
      debugPrint("✅ ${rows.length} lignes détectées."); // LOG:

      List<FlSpot> normal = [];
      List<FlSpot> anomaly = [];

      for (int i = 0; i < rows.length; i++) {
        final row = rows[i];
        if (row.length < 7) continue;

        final x = i.toDouble();
        final y = double.tryParse(row[1].toString()) ?? 0.0;
        final isAnomaly = row[6];

        if (isAnomaly == 1 || isAnomaly == true) {
          anomaly.add(FlSpot(x, y));
          debugPrint("⚠️ Anomalie détectée à l'index $i (y=$y)"); // LOG:
        } else {
          normal.add(FlSpot(x, y));
        }
      }

      debugPrint("📈 Données normales : ${normal.length}, anomalies : ${anomaly.length}"); // LOG:

      setState(() {
        normalPoints = normal;
        anomalyPoints = anomaly;
      });
    } catch (e) {
      debugPrint("❌ Erreur lors du chargement/parsing du CSV: $e"); // LOG:
      setState(() => errorLoading = true);
    }
  }

  Widget buildLegend(Color color, String label) {
    return Row(
      children: [
        Icon(Icons.circle, color: color, size: 12),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("📊 Détection d'anomalies")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: errorLoading
            ? const Center(
                child: Text("❌ Erreur de chargement du fichier CSV.",
                    style: TextStyle(color: Colors.red, fontSize: 16)))
            : (normalPoints.isEmpty && anomalyPoints.isEmpty)
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        "Graphique des données & anomalies détectées",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: LineChart(
                              LineChartData(
                                backgroundColor: Colors.white,
                                gridData: FlGridData(
                                  show: true,
                                  drawVerticalLine: true,
                                  horizontalInterval: 10,
                                  getDrawingHorizontalLine: (value) =>
                                      FlLine(color: Colors.grey[300], strokeWidth: 1),
                                  getDrawingVerticalLine: (value) =>
                                      FlLine(color: Colors.grey[300], strokeWidth: 1),
                                ),
                                titlesData: FlTitlesData(
                                  show: true,
                                  bottomTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 10,
                                      getTitlesWidget: (value, meta) =>
                                          Text('${value.toInt()}', style: const TextStyle(fontSize: 12)),
                                      reservedSize: 30,
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      interval: 10,
                                      getTitlesWidget: (value, meta) =>
                                          Text('${value.toInt()}', style: const TextStyle(fontSize: 12)),
                                      reservedSize: 40,
                                    ),
                                  ),
                                  rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                ),
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(color: Colors.black, width: 1),
                                ),
                                lineBarsData: [
                                  LineChartBarData(
                                    spots: normalPoints,
                                    isCurved: true,
                                    color: Colors.blue,
                                    barWidth: 2,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(show: false),
                                    belowBarData: BarAreaData(
                                      show: true,
                                      color: Colors.blue.withOpacity(0.1),
                                    ),
                                  ),
                                  LineChartBarData(
                                    spots: anomalyPoints,
                                    isCurved: false,
                                    color: Colors.red,
                                    barWidth: 2,
                                    isStrokeCapRound: true,
                                    dotData: FlDotData(show: true),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          buildLegend(Colors.blue, "Données normales"),
                          const SizedBox(width: 24),
                          buildLegend(Colors.red, "Anomalies détectées"),
                        ],
                      ),
                    ],
                  ),
      ),
    );
  }
}
