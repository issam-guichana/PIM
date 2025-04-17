import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:pim_project/services/google_fit_service.dart';

class FitProvider extends ChangeNotifier {
  bool _isLoading = false;
  String? _error;
  Map<String, dynamic> _fitData = {};

  int _steps = 0;
  double _calories = 0.0;
  double _heartRate = 0.0;
  int _heartRateCount = 0;
  int _sleepDurationMinutes = 0;
  List<String> _sleepDetails = [];

  final GoogleFitService _googleFitService = GoogleFitService();

  bool get isLoading => _isLoading;
  String? get error => _error;
  Map<String, dynamic> get fitData => _fitData;
  int get steps => _steps;
  double get calories => _calories;
  double get heartRate => _heartRateCount > 0 ? _heartRate / _heartRateCount : 0;
  List<String> get sleepDetails => _sleepDetails;

  String get sleepInfo {
    if (_sleepDurationMinutes == 0) return "Non disponible";
    final hours = _sleepDurationMinutes ~/ 60;
    final minutes = _sleepDurationMinutes % 60;
    return "${hours}h ${minutes}min de sommeil";
  }

  Future<void> fetchFitDataFromBackend(String jwtToken, dynamic authProvider) async {
    _isLoading = true;
    _error = null;
    _reset();
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse("https://6491-196-234-27-227.ngrok-free.app/api/fit/data"),
        headers: {
          'Authorization': 'Bearer $jwtToken',
          'Content-Type': 'application/json',
        },
      );

      _log("🔄 Réponse backend : ${response.statusCode}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        _fitData = data;
        _log("✅ Données Fit récupérées.");
        _analyzeData(data);

        final accessToken = authProvider.googleAccessToken;
        _log("📥 Token Google reçu : $accessToken");

        if (accessToken != null && accessToken.isNotEmpty) {
          _log("📡 Utilisation du token Google pour récupérer le sommeil...");
          try {
            final sleepData = await _googleFitService.getSleepData(accessToken);

            int total = 0;
            List<String> details = [];
            sleepData.forEach((stage, value) {
              final min = int.tryParse(value) ?? 0;
              total += min;
              details.add("$stage: ${(min ~/ 60)}h ${(min % 60)}min");
            });

            _sleepDurationMinutes = total;
            _sleepDetails = details;
            _log("🟩 Sommeil total (détaillé) : $_sleepDurationMinutes minutes");
            _log("📊 Détails : $_sleepDetails");
          } catch (e) {
            _log("❌ Erreur récupération sommeil via GoogleFitService : $e");
          }
        } else {
          _log("❌ AccessToken Google manquant ou invalide");
        }
      } else {
        _error = 'Erreur serveur (${response.statusCode}) : ${response.body}';
        _log("❌ $_error");
      }
    } catch (e) {
      _error = "Erreur de récupération : $e";
      _log("❌ $_error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void _analyzeData(Map<String, dynamic> data) {
    final buckets = data['bucket'];
    if (buckets == null || buckets is! List || buckets.isEmpty) {
      _log("❗ Aucun bucket disponible.");
      return;
    }

    _log("📊 Total buckets: ${buckets.length}");

    for (final bucket in buckets) {
      final datasets = bucket['dataset'] as List<dynamic>? ?? [];
      for (final dataset in datasets) {
        final points = dataset['point'] as List<dynamic>? ?? [];
        for (final point in points) {
          final type = point['dataTypeName'] ?? dataset['dataSourceId'] ?? '';
          final values = point['value'] as List<dynamic>? ?? [];

          if (values.isEmpty) continue;
          _log("📦 Type: $type");
          _log("🔢 Valeurs: $values");

          for (final value in values) {
            if (value is! Map) continue;

            switch (type) {
              case 'com.google.step_count.delta':
                final stepCount = (value['intVal'] as num?)?.toInt() ?? 0;
                _steps += stepCount;
                _log("👣 Pas ajoutés: $stepCount");
                break;

              case 'com.google.calories.expended':
                final kcal = (value['fpVal'] as num?)?.toDouble() ?? 0.0;
                _calories += kcal;
                _log("🔥 Calories ajoutées: ${kcal.toStringAsFixed(1)} kcal");
                break;

              case 'com.google.heart_rate.bpm':
              case 'com.google.heart_rate.summary':
                final bpm = (value['fpVal'] as num?)?.toDouble();
                if (bpm != null) {
                  _heartRate += bpm;
                  _heartRateCount++;
                  _log("❤️ Mesure fréquence cardiaque: ${bpm.toStringAsFixed(1)} BPM");
                }
                break;

              default:
                _log("🧐 Type de donnée non géré: $type");
            }
          }
        }
      }
    }

    _log(
      "✅ Résumé final :\n"
      "👟 Pas : $_steps\n"
      "🔥 Calories : ${_calories.toStringAsFixed(1)} kcal\n"
      "❤️ BPM moyen : ${heartRate.toStringAsFixed(1)} (${_heartRateCount} mesures)\n"
      "🛌 Sommeil total : $_sleepDurationMinutes minutes",
    );
  }

  void _reset() {
    _fitData = {};
    _steps = 0;
    _calories = 0.0;
    _heartRate = 0.0;
    _heartRateCount = 0;
    _sleepDurationMinutes = 0;
    _sleepDetails = [];
  }

  static const bool _debugMode = true;
  void _log(String message) {
    if (_debugMode) print(message);
  }
}
