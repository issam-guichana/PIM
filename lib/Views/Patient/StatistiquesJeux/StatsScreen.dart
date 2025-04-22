import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  List<dynamic> evaluations = [];

  @override
  void initState() {
    super.initState();
    fetchEvaluations();
  }

  Future<void> fetchEvaluations() async {
    try {
      final userId = "123456"; // 🧠 adapte selon utilisateur connecté
      final response = await http.get(Uri.parse("http://172.16.9.120:3000/evaluation/by-user?userId=$userId"));

      if (response.statusCode == 200) {
        setState(() {
          evaluations = jsonDecode(response.body);
        });
      } else {
        print("❌ Erreur API : ${response.body}");
      }
    } catch (e) {
      print("❌ Exception : $e");
    }
  }

  List<FlSpot> buildScoreSpots() {
    return evaluations.asMap().entries.map((entry) {
      int x = entry.key;
      double y = (entry.value["score"] as num).toDouble();
      return FlSpot(x.toDouble(), y);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Statistiques du Patient"),
        backgroundColor: const Color(0xFF723D92),
      ),
      body: evaluations.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const Text("Évolution des scores", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  AspectRatio(
                    aspectRatio: 1.6,
                    child: LineChart(
                      LineChartData(
                        gridData: FlGridData(show: true),
                        borderData: FlBorderData(show: true),
                        lineBarsData: [
                          LineChartBarData(
                            spots: buildScoreSpots(),
                            isCurved: true,
                            dotData: FlDotData(show: true),
                            barWidth: 4,
                            color: Colors.deepPurple,
                          )
                        ],
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: true),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.builder(
                      itemCount: evaluations.length,
                      itemBuilder: (context, index) {
                        final e = evaluations[index];
                        return Card(
                          child: ListTile(
                            title: Text("Jeu : ${e["gameType"]}"),
                            subtitle: Text("Score: ${e["score"]} | Validité: ${e["validity"]}% | Ordre: ${e["orderAccuracy"]}%\nDate: ${e["playedAt"]}"),
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
            ),
    );
  }
}
