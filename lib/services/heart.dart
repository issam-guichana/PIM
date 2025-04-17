import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';


class HeartRateAnalyzer {
  /// Analyse la fréquence cardiaque moyenne et retourne une recommandation.
  static String analyzeAverageHeartRate(double bpm) {
    if (bpm < 40) {
      return "⚠️ Bradycardie sévère détectée (moins de 40 bpm). Consultez un médecin immédiatement.";
    } else if (bpm < 50) {
      return "⚠️ Fréquence cardiaque basse (bradycardie légère). À surveiller.";
    } else if (bpm >= 50 && bpm <= 90) {
      return "✅ Fréquence cardiaque normale.";
    } else if (bpm > 90 && bpm <= 100) {
      return "⚠️ Fréquence légèrement élevée. Essayez de vous reposer.";
    } else if (bpm > 100 && bpm < 120) {
      return "⚠️ Tachycardie légère détectée. Vérifiez votre niveau de stress ou d'activité.";
    } else {
      return "⚠️ Tachycardie sévère (plus de 120 bpm). Consultez un médecin.";
    }
  }

  /// Analyse la tendance journalière des BPM et détecte les anomalies.
  static String analyzeDailyTrends(Map<int, double> bpmPerDay) {
    List<String> alerts = [];

    bpmPerDay.forEach((day, bpm) {
      if (bpm <= 0) return;

      if (bpm < 50) {
        alerts.add("📉 Jour ${day + 1} : BPM bas (${bpm.toStringAsFixed(1)}).");
      } else if (bpm > 100) {
        alerts.add("📈 Jour ${day + 1} : BPM élevé (${bpm.toStringAsFixed(1)}).");
      }
    });

    return alerts.isEmpty
        ? "✅ Aucune anomalie détectée cette semaine."
        : alerts.join("\n");
  }

  /// Combine les deux analyses pour un rapport global
  static String generateFullReport({
    required double averageBpm,
    required Map<int, double> bpmPerDay,
  }) {
    final avgAnalysis = analyzeAverageHeartRate(averageBpm);
    final dailyAnalysis = analyzeDailyTrends(bpmPerDay);

    return "📊 Analyse globale fréquence cardiaque\n"
        "\n🔢 Moyenne : ${averageBpm.toStringAsFixed(1)} bpm"
        "\n\n$avgAnalysis\n\n📅 Analyse journalière :\n$dailyAnalysis";
  }
}
