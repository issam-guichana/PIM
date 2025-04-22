import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

const String _apiKey = '9cf9242506msh87b3e1dbedb6f2cp103559jsn8e83b5a165fd'; // Remplacez par votre clé API RapidAPI

final chatGptProvider = Provider<ChatGPTService>((ref) {
  return ChatGPTService();
});

class ChatGPTService {
  final String _apiUrl = 'https://chatgpt-42.p.rapidapi.com/aitohuman';

  Future<String> getResponse(String prompt) async
   {
  try {
    // Create the request body
    final requestBody = jsonEncode({
      "text": "$prompt Réponds-moi en arabe." // Demander explicitement une réponse en arabe
    });

    debugPrint("[LOG] Sending request to ChatGPT: $requestBody");

    final response = await http.post(
      Uri.parse(_apiUrl),
      headers: {
        'x-rapidapi-key': _apiKey,
        'x-rapidapi-host': 'chatgpt-42.p.rapidapi.com',
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    debugPrint("[LOG] Full API response: ${response.body}");

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      // Ensure the structure of the response is correct
      if (json.containsKey('result')) {
        final List<dynamic> answerList = json['result'];
        if (answerList.isNotEmpty) {
          return answerList[0]; // Extract the first item
        } else {
          throw Exception("Empty result list: ${response.body}");
        }
      } else {
        throw Exception("Unexpected API response: ${response.body}");
      }
    } else {
      throw Exception("API Error: ${response.statusCode}, Body: ${response.body}");
    }
  } catch (e) {
    debugPrint("[LOG] Error fetching response from ChatGPT: $e");
    rethrow; // Propagate the error for handling in `_speak`
  }
}
}