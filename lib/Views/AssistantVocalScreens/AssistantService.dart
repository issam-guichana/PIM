import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'SpeechInteractionPage.dart';

class SpeechService {
  bool _isSpeechInitialized = false;
  bool _isListening = false;
  bool _isAIResponding = false;
  String _userMessage = '';
  String _aiResponse = '';
  List<Message> _conversationHistory = [];
  final SpeechToText _speechToText = SpeechToText();
  Function(String, bool)? _onSpeechResult; // Store the callback
  Function(bool, bool, String, String, List<Message>)? _onStatusChange;

  static const String _geminiApiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  static const String _geminiApiKey = 'AIzaSyB-lwjXMpc6O-pb7ZYSkXpNynowfQLwKKU';

  Future<String> _getCustomInstruction() async {
    final prefs = await SharedPreferences.getInstance();
    final patientName = prefs.getString('patient_name') ?? 'المريض';
    final patientFamily = prefs.getString('patient_family') ?? 'غير متوفر';
    final patientTasks = prefs.getString('patient_tasks') ?? 'غير متوفر';
    final patientMedication = prefs.getString('patient_medication') ?? 'غير متوفر';
    final emergencyContact = prefs.getString('emergency_contact') ?? 'غير متوفر';
    final medicalConditions = prefs.getString('medical_conditions') ?? 'غير متوفر';
    final dietaryNeeds = prefs.getString('dietary_needs') ?? 'غير متوفر';

    return '''
You are a friendly and patient vocal assistant designed to help Alzheimer's patients in Tunisian dialect (Derja) only.

⚠️ Do NOT use Modern Standard Arabic or English under any circumstance.

✅ Always respond in spoken Tunisian (Derja), using natural words and expressions as Tunisians use in everyday conversations. Avoid formal Arabic and foreign translations.

Patient Information:
- Name: $patientName
- Family: $patientFamily
- Daily Tasks: $patientTasks
- Medication Schedule: $patientMedication
- Emergency Contact: $emergencyContact
- Medical Conditions: $medicalConditions
- Dietary Needs: $dietaryNeeds

Use this information to personalize responses, remind about tasks, medication, or dietary needs, mention family members appropriately, and provide emergency contact details when needed.

Your responses should be:
- Short (5–7 words)
- Clear and simple to understand
- Friendly, warm, and reassuring

You can:
- Gently remind about daily tasks (e.g., medication, eating)
- Help with orientation (e.g., place, family)
- Ask simple, engaging questions
- Provide emergency contact information if requested

If a question is repeated, answer patiently with a slightly varied reply.

Keep the conversation slow, kind, and positive at all times.
''';
  }

  void initSpeech({
    required Function(String, bool) onSpeechResult,
    required Function(bool, bool, String, String, List<Message>) onStatusChange,
  }) async {
    _onSpeechResult = onSpeechResult; // Store the callback
    _onStatusChange = onStatusChange; // Store the status change callback
    try {
      final enabled = await _speechToText.initialize(
        onStatus: (status) => debugPrint('Speech status: $status'),
        onError: (error) => debugPrint('Speech error: $error'),
      );
      _isSpeechInitialized = enabled;
      _notifyStatus();
    } catch (e) {
      debugPrint('Speech initialization error: $e');
      _isSpeechInitialized = false;
      _notifyStatus();
    }
  }

  void startListening() async {
    if (!_isSpeechInitialized) return;

    _isListening = true;
    _userMessage = '';
    _notifyStatus();

    await _speechToText.listen(
      onResult: (result) {
        _userMessage = result.recognizedWords.toLowerCase();
        _notifyStatus();
        _onSpeechResult?.call(result.recognizedWords, result.finalResult); // Invoke the callback
      },
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
      localeId: 'ar-TN',
    );
  }

  void stopListening() async {
    await _speechToText.stop();
    _isListening = false;
    _notifyStatus();
    if (_userMessage.trim().isNotEmpty) {
      _conversationHistory.add(Message(text: _userMessage, isUser: true));
      await _handleAIResponse();
    }
  }

  void clearConversation() {
    _conversationHistory.clear();
    _userMessage = '';
    _aiResponse = '';
    _notifyStatus();
  }

  String getStatusText() {
    if (!_isSpeechInitialized) return 'Speech not available';
    if (_isListening) return 'Listening to you...';
    if (_isAIResponding) return 'AI is responding...';
    return 'Press the mic to start';
  }

  bool get isSpeechInitialized => _isSpeechInitialized;

  void _notifyStatus() {
    _onStatusChange?.call(_isListening, _isAIResponding, _userMessage, _aiResponse, _conversationHistory);
  }

  String _getConversationContext() {
    final relevantHistory = _conversationHistory.length > 10
        ? _conversationHistory.sublist(_conversationHistory.length - 10)
        : _conversationHistory;

    String context = "Previous conversation:\n";
    for (var message in relevantHistory) {
      context += "${message.isUser ? 'User' : 'Assistant'}: ${message.text}\n";
    }
    return context;
  }

  Future<void> _handleAIResponse() async {
    _isAIResponding = true;
    _notifyStatus();

    final conversationContext = _getConversationContext();
    final customInstruction = await _getCustomInstruction();

    try {
      final response = await http.post(
        Uri.parse(_geminiApiUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': _geminiApiKey,
        },
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': customInstruction},
                {
                  'text': 'Current conversation history:\n$conversationContext\nUser\'s latest message: $_userMessage\nPlease respond to this latest message with the conversation context in mind:'
                }
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'topK': 40,
            'topP': 0.95,
            'maxOutputTokens': 1024,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _aiResponse = data['candidates'][0]['content']['parts'][0]['text'] ?? 'ما فماش رد من الـ AI';
        _conversationHistory.add(Message(text: _aiResponse, isUser: false));
        await _speakWithFlutterTTS(_aiResponse);
      } else {
        _aiResponse = 'خطأ: ${response.statusCode}';
        _conversationHistory.add(Message(text: _aiResponse, isUser: false));
        debugPrint('Response status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
      }
    } catch (e) {
      _aiResponse = 'مشكلة: $e';
      _conversationHistory.add(Message(text: _aiResponse, isUser: false));
    } finally {
      _isAIResponding = false;
      _notifyStatus();
    }
  }

  Future<void> _speakWithPlayHT(String text) async {
    if (text.trim().isEmpty) return;
    const String apiKey = 'ak-0a793beda67745669bf4aca1c2f98a53'; // Replace with your PlayHT API key
    const String userId = 'SY9YsgOpgvV6m8dT6URlDqup3Gf2'; // Replace with your PlayHT user ID
    final prefs = await SharedPreferences.getInstance();
    final voiceId = prefs.getString('playht_voice_id') ?? 's3://voice-cloning-zero-shot/d9ff78ba-d016-47f6-b0cd-dd8d6928566d/original/manifest.json';

    try {
      final response = await http.post(
        Uri.parse('https://api.play.ht/api/v2/tts'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'X-User-Id': userId,
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({
          'text': text,
          'voice': voiceId,
          'voice_engine': 'PlayHT2.0',
          'sample_rate': 24000,
          'format': 'mp3',
          'speed': 1.0,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final audioUrl = data['audioUrl'];
        if (audioUrl != null) {
          final player = AudioPlayer();
          await player.play(UrlSource(audioUrl));
        } else {
          debugPrint('No audio URL in response: $data');
        }
      } else {
        debugPrint('TTS Error ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      debugPrint('TTS Exception: $e');
    }
  }

  Future<void> _speakWithFlutterTTS(String text) async {
    if (text.trim().isEmpty) return;

    final FlutterTts flutterTts = FlutterTts();
    try {
      await flutterTts.setLanguage('ar-TN');
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.setVolume(1.0);
      await flutterTts.setPitch(1.0);
      await flutterTts.speak(text);
    } catch (e) {
      debugPrint('Flutter TTS Exception: $e');
    }
  }

  Future<void> scheduleReminder(String message, DateTime time) async {
    final delay = time.difference(DateTime.now());
    if (delay.isNegative) return;

    Future.delayed(delay, () async {
      await _speakWithFlutterTTS(message);
      _conversationHistory.add(Message(text: "🔔 $message", isUser: false));
      _notifyStatus();
    });
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  void dispose() {
    _speechToText.stop();
  }
}