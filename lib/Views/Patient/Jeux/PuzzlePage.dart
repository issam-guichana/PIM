import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

class PuzzlePage extends StatefulWidget {
  const PuzzlePage({super.key});

  @override
  State<PuzzlePage> createState() => _PuzzlePageState();
}

class _PuzzlePageState extends State<PuzzlePage> {
  late final WebViewController _controller;
  String extractedData = "Aucune donnée reçue";

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..addJavaScriptChannel(
        'ScoreChannel',
        onMessageReceived: (JavaScriptMessage message) {
          setState(() {
            extractedData = message.message;
          });
          print("🔥 Résultat extrait : ${message.message}");
          _handleExtractedData(message.message);
        },
      )
      ..setUserAgent(
        "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) "
        "AppleWebKit/605.1.15 (KHTML, like Gecko) "
        "Version/13.0.3 Mobile/15E148 Safari/604.1",
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (url) {
            _injectPersistentZoom();
            _injectScoreExtraction();
          },
        ),
      )
      ..loadRequest(Uri.parse('https://games.memory-motivation.org/?lang=fr'));
  }

  void _injectPersistentZoom() {
    _controller.runJavaScript('''
      (function() {
        function applyZoom() {
          var viewport = document.querySelector('meta[name=viewport]');
          if (!viewport) {
            viewport = document.createElement('meta');
            viewport.name = 'viewport';
            document.head.appendChild(viewport);
          }
          viewport.setAttribute('content', 'width=device-width, initial-scale=0.8, maximum-scale=2.0, user-scalable=yes');
          document.body.style.zoom = '1';
          document.body.style.transformOrigin = '0 0';
          document.body.style.transform = 'scale(0.75)';
        }

        applyZoom();
        setInterval(applyZoom, 1000);
      })();
    ''');
  }

  void _injectScoreExtraction() {
    _controller.runJavaScript('''
      (function() {
        function extractResultText() {
          const bodyText = document.body.innerText;
          if (bodyText.includes("score") || bodyText.includes("Score") || bodyText.includes("points")) {
            const lines = bodyText.split("\\n").filter(l => l.trim() !== "");
            const scoreLines = lines.filter(line =>
              line.toLowerCase().includes("score") ||
              line.toLowerCase().includes("points") ||
              line.toLowerCase().includes("validité") ||
              line.toLowerCase().includes("réponses") ||
              line.match(/\\d+\\s?points?/)
            );
            const result = scoreLines.slice(0, 10).join("\\n");
            if (result.length > 0) {
              ScoreChannel.postMessage(result);
            }
          }
        }

        extractResultText();
        setInterval(extractResultText, 2000);
      })();
    ''');
  }

  /// ✅ Analyse et envoi des données extraites
  void _handleExtractedData(String text) async {
    final score = int.tryParse(RegExp(r'score\s*de\s*:\s*(\d+)', caseSensitive: false).firstMatch(text)?.group(1) ?? '0')!;
    final validite = double.tryParse(RegExp(r'validité.*?:\s*(\d+)', caseSensitive: false).firstMatch(text)?.group(1) ?? '0')!;
    final ordre = double.tryParse(RegExp(r'ordre.*?:\s*(\d+)', caseSensitive: false).firstMatch(text)?.group(1) ?? '0')!;
    final niveau = int.tryParse(RegExp(r'niveau\s*(\d+)', caseSensitive: false).firstMatch(text)?.group(1) ?? '1')!;

    await sendEvaluationToServer(
      userId: "123456", // Remplace dynamiquement plus tard
      gameType: "Quiz MeMo",
      score: score,
      level: niveau,
      validity: validite,
      orderAccuracy: ordre,
    );
  }

  /// ✅ Fonction pour envoyer au backend NestJS
  Future<void> sendEvaluationToServer({
    required String userId,
    required String gameType,
    required int score,
    required int level,
    required double validity,
    required double orderAccuracy,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    try {
      final response = await http.post(
        Uri.parse('http://172.16.9.120:3000/evaluation'), // 🔁 Backend NestJS
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "userId": userId,
          "gameType": gameType,
          "score": score,
          "level": level,
          "validity": validity,
          "orderAccuracy": orderAccuracy,
          "playedAt": DateTime.now().toIso8601String(),
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print("✅ Évaluation envoyée avec succès");
      } else {
        print("❌ Erreur d'envoi : ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("❌ Exception lors de l'envoi : $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jeu de Puzzle'),
        backgroundColor: const Color(0xFF723D92),
      ),
      body: Column(
        children: [
          Expanded(
            child: WebViewWidget(controller: _controller),
          ),
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.all(8.0),
            child: Text(
              extractedData,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
