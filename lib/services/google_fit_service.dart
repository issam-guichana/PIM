import 'dart:convert';
import 'package:http/http.dart' as http;

class GoogleFitService {
  final String _baseUrl = "https://www.googleapis.com/fitness/v1/users/me/dataset:aggregate";

  /// Récupère et analyse les données de sommeil par stades
  Future<Map<String, dynamic>> getSleepData(String accessToken) async {
    final now = DateTime.now();
    final startTime = now.subtract(Duration(days: 30)).millisecondsSinceEpoch * 1000000;
    final endTime = now.millisecondsSinceEpoch * 1000000;

    final body = {
      "aggregateBy": [
        { "dataTypeName": "com.google.sleep.segment" }
      ],
      "bucketByTime": { "durationMillis": 86400000 },
      "startTimeMillis": startTime ~/ 1000000,
      "endTimeMillis": endTime ~/ 1000000,
    };

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        "Authorization": "Bearer $accessToken",
        "Content-Type": "application/json",
      },
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      final result = json.decode(response.body);
      final Map<String, int> stageDurations = {
        "awake": 0,
        "light": 0,
        "deep": 0,
        "rem": 0,
      };

      for (final bucket in result["bucket"] ?? []) {
        for (final dataset in bucket["dataset"] ?? []) {
          for (final point in dataset["point"] ?? []) {
            final startNs = int.tryParse(point["startTimeNanos"]?.toString() ?? '') ?? 0;
            final endNs = int.tryParse(point["endTimeNanos"]?.toString() ?? '') ?? 0;
            final stageType = int.tryParse(point["value"]?[0]?["intVal"]?.toString() ?? '') ?? -1;

            final durationMin = ((endNs - startNs) / 60000000).round();

            switch (stageType) {
              case 1: // Sleep
              case 2: // Light sleep
                stageDurations["light"] = stageDurations["light"]! + durationMin;
                break;
              case 3: // Deep sleep
                stageDurations["deep"] = stageDurations["deep"]! + durationMin;
                break;
              case 4: // REM
                stageDurations["rem"] = stageDurations["rem"]! + durationMin;
                break;
              case 5: // Awake
                stageDurations["awake"] = stageDurations["awake"]! + durationMin;
                break;
              default:
                break;
            }
          }
        }
      }

      return {
        'light': stageDurations["light"].toString(),
        'deep': stageDurations["deep"].toString(),
        'rem': stageDurations["rem"].toString(),
        'awake': stageDurations["awake"].toString(),
      };
    } else {
      throw Exception("Erreur Google Fit API: ${response.statusCode} ${response.body}");
    }
  }
}
