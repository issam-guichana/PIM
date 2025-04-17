import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:pim_project/Views/HomePages/anomaly_asset_screen.dart';
import 'package:http/http.dart' as http;

class FitScreen extends StatefulWidget {
  final Map<String, dynamic> fitData;
  final String accessToken;

  const FitScreen({
    Key? key,
    required this.fitData,
    required this.accessToken,
  }) : super(key: key);

  @override
  _FitScreenState createState() => _FitScreenState();
}

class _FitScreenState extends State<FitScreen> {
  int steps = 0;
  double calories = 0.0;
  double heartRate = -1.0;
  Duration totalSleepDuration = Duration.zero;
  bool dataAnalyzed = false;

  final List<String> labels = ["Lun", "Mar", "Mer", "Jeu", "Ven", "Sam", "Dim"];
  final Map<int, int> stepsPerDay = {for (var i = 0; i < 7; i++) i: 0};
  final Map<int, double> caloriesPerDay = {for (var i = 0; i < 7; i++) i: 0.0};
  final Map<int, double> heartRatePerDay = {for (var i = 0; i < 7; i++) i: 0.0};
  final Map<int, Duration> sleepPerDay = {
    for (var i = 0; i < 7; i++) i: Duration.zero
  };
  final Map<int, int> bpmCountPerDay = {for (var i = 0; i < 7; i++) i: 0};

  final Color stepsColor = Colors.blueAccent;
  final Color caloriesColor = Colors.orangeAccent;
  final Color heartRateColor = Colors.redAccent;
  final Color sleepColor = Colors.purpleAccent;

  bool showSteps = true;
  bool showCalories = true;
  bool showHeartRate = true;
  bool showSleep = true;

  @override
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _requestPermissions();
      _analyzeData(widget.fitData);

      if (widget.accessToken.isNotEmpty) {
        await _loadSleepSessions30Days();
      } else {
        print("❌ AccessToken est vide dans initState");
      }
    });
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.activityRecognition.status;
    if (!status.isGranted) {
      await Permission.activityRecognition.request();
    }
  }

  int normalizeMillis(dynamic raw) {
    final value = int.tryParse(raw.toString()) ?? 0;
    return value > 8640000000000000 ? (value ~/ 1000000) : value;
  }

  void _analyzeData(Map<String, dynamic> fitData) {
    print("🔍 Analyse des données démarrée...");
    print("✅ Données reçues : (bucket)");

    int totalSteps = 0;
    double totalCalories = 0.0;
    double totalBpm = 0.0;
    int bpmCount = 0;
    Duration sleepDuration = Duration.zero;

    final List bucketList = fitData['bucket'] ?? [];
    print("📦 Nombre de buckets : ${bucketList.length}");

    for (final bucket in bucketList) {
      final datasets = bucket['dataset'];
      if (datasets is! List) continue;

      for (final dataset in datasets) {
        final points = dataset['point'];
        if (points is! List || points.isEmpty) continue;

        for (final point in points) {
          final type = point['dataTypeName'] ?? dataset['dataSourceId'] ?? '';
          final startMillis = normalizeMillis(
              point['startTimeMillis'] ?? point['startTimeNanos']);
          final endMillis =
              normalizeMillis(point['endTimeMillis'] ?? point['endTimeNanos']);
          final date = DateTime.fromMillisecondsSinceEpoch(startMillis);
          final weekdayIndex = (date.weekday - 1).clamp(0, 6);

          print("➡️ Type détecté : $type | Jour : ${labels[weekdayIndex]}");
          print("📌 Donnée brute point: ${jsonEncode(point)}");

          final values = point['value'];
          if (values is! List) continue;

          for (final value in values) {
            if (value is! Map<String, dynamic>) continue;
            final val = value['fpVal'] ?? value['intVal'];

            if (type.toString().contains('step_count') && val is num) {
              totalSteps += val.toInt();
              stepsPerDay[weekdayIndex] =
                  (stepsPerDay[weekdayIndex] ?? 0) + val.toInt();
              print("👣 Pas ajoutés : $val");
            } else if (type.toString().contains('calories') && val is num) {
              totalCalories += val.toDouble();
              caloriesPerDay[weekdayIndex] =
                  (caloriesPerDay[weekdayIndex] ?? 0.0) + val.toDouble();
              print("🔥 Calories ajoutées : $val");
            } else if (type.toString().contains('heart_rate') && val is num) {
              totalBpm += val.toDouble();
              bpmCount++;
              heartRatePerDay[weekdayIndex] =
                  (heartRatePerDay[weekdayIndex] ?? 0.0) + val.toDouble();
              bpmCountPerDay[weekdayIndex] =
                  (bpmCountPerDay[weekdayIndex] ?? 0) + 1;
              print("❤️ BPM reçu : $val");
            } else if (type.toString().contains('sleep') &&
                endMillis > startMillis) {
              final duration = Duration(milliseconds: endMillis - startMillis);
              if (duration.inMinutes > 0) {
                sleepDuration += duration;
                sleepPerDay[weekdayIndex] =
                    (sleepPerDay[weekdayIndex] ?? Duration.zero) + duration;
                print("😴 Sommeil ajouté : ${duration.inMinutes} min");
                print(
                    "📅 Durée totale du sommeil pour ${labels[weekdayIndex]} : ${_formatDuration(sleepPerDay[weekdayIndex] ?? Duration.zero)}");
              } else {
                print(
                    "⚠️ Durée de sommeil invalide détectée pour ${labels[weekdayIndex]}.");
              }
            } else {
              print("⚠️ Type non traité ou valeur inconnue : $type => $value");
            }
          }
        }
      }
    }

    for (var i = 0; i < 7; i++) {
      if ((bpmCountPerDay[i] ?? 0) > 0) {
        heartRatePerDay[i] = (heartRatePerDay[i] ?? 0.0) / bpmCountPerDay[i]!;
        print(
            "📊 BPM moyen pour ${labels[i]} : ${heartRatePerDay[i]!.toStringAsFixed(1)}");
      }
    }

    setState(() {
      steps = totalSteps;
      calories = totalCalories;
      heartRate = bpmCount > 0 ? totalBpm / bpmCount : -1;
      totalSleepDuration = sleepDuration;
      dataAnalyzed = true;
    });

    print(
        "✅ Analyse terminée. Pas : $steps, Calories : $calories, BPM : $heartRate, Sommeil : ${_formatDuration(sleepDuration)}");
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    return "${hours}h ${minutes}min";
  }

  Future<void> _loadSleepSessions30Days() async {
    final now = DateTime.now();
    final start =
        now.subtract(const Duration(days: 30)).toUtc().toIso8601String();
    final end = now.toUtc().toIso8601String();

    final url = Uri.parse(
      'https://www.googleapis.com/fitness/v1/users/me/sessions?startTime=$start&endTime=$end',
    );

    final token = widget.accessToken;
    if (token.isEmpty) {
      print("❌ AccessToken manquant");
      return;
    }

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("📥 Sleep sessions status: ${response.statusCode}");

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final sessions = data['session'];

      if (sessions == null || sessions.isEmpty) {
        print("⚠️ Aucune session détectée dans la réponse.");
      } else {
        Duration total = Duration.zero;
        print("🔍 ${sessions.length} sessions récupérées :");

        for (final s in sessions) {
          final name = s['name'] ?? "Sans nom";
          final activityType = s['activityType'];
          final startMillis = int.tryParse(s['startTimeMillis'] ?? '') ?? 0;
          final endMillis = int.tryParse(s['endTimeMillis'] ?? '') ?? 0;
          final start = DateTime.fromMillisecondsSinceEpoch(startMillis);
          final end = DateTime.fromMillisecondsSinceEpoch(endMillis);
          final duration = Duration(milliseconds: endMillis - startMillis);

          print(
              "📦 Session: $name | Type: $activityType | ${start.toLocal()} ➡️ ${end.toLocal()} | Durée: ${duration.inMinutes} min");

          // Seul le type 72 est du sommeil
          if (activityType == 72 && duration.inMinutes > 0) {
            total += duration;
            print("😴 Sommeil ajouté : ${duration.inMinutes} minutes");
          }
        }

        setState(() {
          totalSleepDuration = total;
        });

        print("✅ Total sommeil sur 30j : ${_formatDuration(total)}");
      }
    } else {
      print("❌ Erreur récupération sessions : ${response.body}");
    }
  }

  Future<void> _testSleepSessions() async {
    final now = DateTime.now();
    final start =
        now.subtract(const Duration(days: 30)).toUtc().toIso8601String();
    final end = now.toUtc().toIso8601String();

    final url = Uri.parse(
      'https://www.googleapis.com/fitness/v1/users/me/sessions?startTime=$start&endTime=$end',
    );

    final token = widget.accessToken;
    if (token.isEmpty) {
      print("❌ AccessToken manquant");
      return;
    }

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print("📥 Sleep sessions status: ${response.statusCode}");
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final sessions = data['session'];
      for (final s in sessions) {
        print(
            "🛌 ${s['name']} (${s['activityType']}) | ${s['startTimeMillis']} - ${s['endTimeMillis']}");
      }
    } else {
      print("❌ Error retrieving sessions: ${response.body}");
    }
  }

  Widget _buildSleepSection() {
    if (totalSleepDuration.inMinutes == 0) {
      return Container(
        margin: EdgeInsets.symmetric(vertical: 12),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                "Aucune donnée de sommeil disponible.",
                style: TextStyle(
                    color: Colors.red.shade800, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );
    } else {
      return Text(
        '😴 Sommeil total : ${_formatDuration(totalSleepDuration)}',
        style: TextStyle(fontWeight: FontWeight.bold),
      );
    }
  }

  Widget _buildStatCard(String emoji, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)],
      ),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 16, color: Colors.black54)),
              Text(value,
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildLegendItem(
      String text, Color color, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isActive ? color.withOpacity(0.2) : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: isActive ? color : Colors.transparent, width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
                width: 12,
                height: 12,
                decoration:
                    BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 6),
            Text(
              text,
              style: TextStyle(
                color: Colors.black,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 10,
      children: [
        _buildLegendItem('Pas', stepsColor, showSteps, () {
          setState(() => showSteps = !showSteps);
        }),
        _buildLegendItem('Calories', caloriesColor, showCalories, () {
          setState(() => showCalories = !showCalories);
        }),
        _buildLegendItem('BPM', heartRateColor, showHeartRate, () {
          setState(() => showHeartRate = !showHeartRate);
        }),
        _buildLegendItem('Sommeil', sleepColor, showSleep, () {
          setState(() => showSleep = !showSleep);
        }),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Donnes Pour 30J'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              _buildStatCard("👣", "Pas", "$steps pas"),
              _buildStatCard("🔥", "Calories", "$calories Cal"),
              _buildStatCard(
                  "❤️",
                  "BPM moyen",
                  heartRate >= 0
                      ? "${heartRate.toStringAsFixed(1)} BPM"
                      : "Non disponible"),
              _buildStatCard(
                  "😴", "Sommeil", _formatDuration(totalSleepDuration)),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const AnomalyChartScreen()),
                  );
                },
                icon: const Icon(Icons.analytics_outlined),
                label: const Text("Voir les anomalies détectées"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _testSleepSessions,
                child: const Text("Tester les sessions de sommeil"),
              ),
              if (dataAnalyzed) ...[
                _buildLegend(),
                const SizedBox(height: 20),
                SizedBox(
                  height: 200,
                  child: _buildChart(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart() {
    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          if (showSteps)
            LineChartBarData(
              spots: _generateChartData(stepsPerDay),
              isCurved: true,
              color: stepsColor,
            ),
          if (showCalories)
            LineChartBarData(
              spots: _generateChartData(caloriesPerDay),
              isCurved: true,
              color: caloriesColor,
            ),
          if (showHeartRate)
            LineChartBarData(
              spots: _generateChartData(heartRatePerDay),
              isCurved: true,
              color: heartRateColor,
            ),
          if (showSleep)
            LineChartBarData(
              spots: _generateChartData(sleepPerDay),
              isCurved: true,
              color: sleepColor,
            ),
        ],
      ),
    );
  }

  List<FlSpot> _generateChartData(Map<int, dynamic> data) {
    return data.entries
        .map((entry) => FlSpot(
              entry.key.toDouble(),
              entry.value is Duration
                  ? entry.value.inMinutes.toDouble()
                  : (entry.value as num).toDouble(),
            ))
        .toList();
  }
}
