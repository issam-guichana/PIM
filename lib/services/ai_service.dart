import 'dart:convert';
import 'package:http/http.dart' as http;

class AiAnalysisService {
  static const String _apiUrl = 'https://19f4-196-225-52-196.ngrok-free.app/api/ai/analyze'; // ⚠️ change avec ton vrai backend

  static Future<String> sendFitDataToBackend(Map<String, dynamic> fitData) async {
    try {
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(fitData),
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        if (body['analysis'] != null) {
          return body['analysis'];
        } else {
          return 'Aucune analyse retournée.';
        }
      } else {
        print("❌ Erreur backend : ${response.body}");
        return 'Erreur lors de la récupération de l’analyse.';
      }
    } catch (e) {
      print('❌ Exception : $e');
      return 'Erreur de connexion avec le serveur IA.';
    }
  }
}

