import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ChatService {
  final String baseUrl = "http://172.20.10.3:3000";

  Future<Map<String, String>> _getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken') ?? '';
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<dynamic>> getChatHistory(int otherUserId) async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/chat/history?otherUserId=$otherUserId'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw _handleError(response);
  }

  Future<List<dynamic>> getConversations() async {
    final headers = await _getHeaders();
    final response = await http.get(
      Uri.parse('$baseUrl/chat/conversations'),
      headers: headers,
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }
    throw _handleError(response);
  }

  Future<void> deleteMessage(int messageId) async {
    final headers = await _getHeaders();
    final response = await http.delete(
      Uri.parse('$baseUrl/chat/$messageId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

  Future<void> markMessageAsRead(int messageId) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl/chat/mark-read/$messageId'),
      headers: headers,
    );

    if (response.statusCode != 200) {
      throw _handleError(response);
    }
  }

  dynamic _handleError(http.Response response) {
    switch (response.statusCode) {
      case 401:
        throw Exception('Session expirée - Veuillez vous reconnecter');
      case 404:
        throw Exception('Ressource non trouvée');
      case 500:
        throw Exception('Erreur serveur');
      default:
        throw Exception('Échec de la requête: ${response.reasonPhrase}');
    }
  }
}
