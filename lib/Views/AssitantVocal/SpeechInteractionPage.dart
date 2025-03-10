import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'dart:math' as math;
import 'package:http/http.dart' as http;
import 'dart:convert';

class SpeechInteractionPage extends StatefulWidget {
  const SpeechInteractionPage({super.key});
  @override
  _SpeechInteractionPageState createState() => _SpeechInteractionPageState();
}

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({required this.text, required this.isUser})
      : timestamp = DateTime.now();
}

class _SpeechInteractionPageState extends State<SpeechInteractionPage>
    with SingleTickerProviderStateMixin {
  bool isListening = false;
  bool isAIResponding = false;
  String userMessage = '';
  String aiResponse = '';
  bool _isSpeechInitialized = false;

  // List to store the entire conversation history
  List<Message> conversationHistory = [];

  final SpeechToText _speechToText = SpeechToText();
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();

  // Gemini configuration
  static const String _geminiApiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  static const String _geminiApiKey = 'AIzaSyB-lwjXMpc6O-pb7ZYSkXpNynowfQLwKKU';

  static const String _customInstruction = '''
   You are a friendly and patient vocal assistant designed to help Alzheimer's patients in Tunisian language(Darija).
    Your responses should be short (5-7 words), clear, and simple to understand.
     Speak in a warm and reassuring tone, avoiding complex words. If the user is confused, respond calmly and supportively.
      Provide gentle reminders for daily tasks (e.g., medication, eating) and assist with orientation (e.g., reminding them where they are or who their family members are).
       If a user repeats a question, answer without frustration, varying the response slightly.
    Ask simple engaging questions to keep them talking. Keep the conversation slow, friendly, and positive.
  ''';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      final enabled = await _speechToText.initialize(
        onStatus: (status) => debugPrint('Speech status: $status'),
        onError: (error) => debugPrint('Speech error: $error'),
      );
      if (mounted) {
        setState(() => _isSpeechInitialized = enabled);
      }
    } catch (e) {
      debugPrint('Speech initialization error: $e');
      if (mounted) {
        setState(() => _isSpeechInitialized = false);
      }
    }
  }

  void _startListening() async {
    if (!_isSpeechInitialized) return;

    setState(() {
      isListening = true;
      userMessage = '';
      _animationController.repeat();
    });

    await _speechToText.listen(
      onResult: _onSpeechResult,
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
      listenMode: ListenMode.confirmation,
      localeId: 'ar-TN',
    );
  }

  void _stopListening() async {
    await _speechToText.stop();
    if (mounted) {
      setState(() {
        isListening = false;
        _animationController.stop();
      });
    }
    if (userMessage.trim().isNotEmpty) {
      // Add user message to conversation history
      setState(() {
        conversationHistory.add(Message(text: userMessage, isUser: true));
      });
      await _handleAIResponse();
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (mounted) {
      setState(() {
        userMessage = result.recognizedWords;
      });
    }
    if (result.finalResult) {
      _stopListening();
    }
  }

  // Create a formatted conversation history for context
  String _getConversationContext() {
    // Limit to the last 10 exchanges to avoid token limits
    final relevantHistory = conversationHistory.length > 10
        ? conversationHistory.sublist(conversationHistory.length - 10)
        : conversationHistory;

    String context = "Previous conversation:\n";
    for (var message in relevantHistory) {
      context += "${message.isUser ? 'User' : 'Assistant'}: ${message.text}\n";
    }
    return context;
  }

  Future<void> _handleAIResponse() async {
    if (mounted) {
      setState(() {
        isAIResponding = true;
        _animationController.repeat();
      });
    }

    // Get conversation context to provide to the AI
    final conversationContext = _getConversationContext();

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
                {'text': _customInstruction},
                {'text': 'Current conversation history:\n$conversationContext\nUser\'s latest message: $userMessage\nPlease respond to this latest message with the conversation context in mind:'}
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
        final aiResponseText = data['candidates'][0]['content']['parts'][0]['text'] ?? 'ما فماش رد من الـ AI';

        if (mounted) {
          setState(() {
            aiResponse = aiResponseText;
            // Add AI response to conversation history
            conversationHistory.add(Message(text: aiResponseText, isUser: false));
          });

          // Scroll to bottom after adding new messages
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_scrollController.hasClients) {
              _scrollController.animateTo(
                _scrollController.position.maxScrollExtent,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
              );
            }
          });
        }
      } else {
        if (mounted) {
          setState(() {
            aiResponse = 'خطأ: ${response.statusCode}';
            conversationHistory.add(Message(text: aiResponse, isUser: false));
          });
          print('Response status: ${response.statusCode}');
          print('Response body: ${response.body}');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          aiResponse = 'مشكلة: $e';
          conversationHistory.add(Message(text: aiResponse, isUser: false));
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          isAIResponding = false;
          _animationController.stop();
        });
      }
    }
  }

  @override
  void dispose() {
    _speechToText.stop();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF723D92),
        elevation: 0,
        title: const Text('AI Assistant', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Add clear conversation button
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () {
              setState(() {
                conversationHistory.clear();
                userMessage = '';
                aiResponse = '';
              });
            },
            tooltip: 'مسح المحادثة',
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              height: 100,
              decoration: const BoxDecoration(
                color: Color(0xFF723D92),
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Center(
                child: Text(
                  _getStatusText(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            Expanded(
              child: conversationHistory.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline,
                        size: 80,
                        color: Colors.grey[300]),
                    const SizedBox(height: 16),
                    Text(
                      'ابدأ المحادثة باش تتواصل معايا',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              )
                  : ListView.builder(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                itemCount: conversationHistory.length,
                itemBuilder: (context, index) {
                  final message = conversationHistory[index];
                  return _buildMessageBubble(
                      message: message.text, isUser: message.isUser);
                },
              ),
            ),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  height: 80,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: CustomPaint(
                    size: const Size(double.infinity, 80),
                    painter: WaveformPainter(
                      animation: _animationController,
                      isActive: isListening || isAIResponding,
                      color: const Color(0xFF723D92),
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: FloatingActionButton(
                backgroundColor: isListening ? Colors.red : const Color(0xFF723D92),
                onPressed: _isSpeechInitialized
                    ? (isListening ? _stopListening : _startListening)
                    : null,
                child: Icon(
                  isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getStatusText() {
    if (!_isSpeechInitialized) return 'الصوت غير متوفر';
    if (isListening) return 'نسمع فيك...';
    if (isAIResponding) return 'الـ AI يجاوبك...';
    return 'اضغط على الميكرو باش تبدا';
  }

  Widget _buildMessageBubble({required String message, required bool isUser}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser ? const Color(0xFF723D92) : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final Animation<double> animation;
  final bool isActive;
  final Color color;

  WaveformPainter({
    required this.animation,
    required this.isActive,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive) return;

    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    const bars = 40;
    final barWidth = size.width / bars;
    final centerY = size.height / 2;

    for (var i = 0; i < bars; i++) {
      final x = i * barWidth;
      final normalized = (i / bars) * 2 * math.pi;
      final wave = math.sin(normalized + (animation.value * 4 * math.pi));
      final barHeight = (size.height * 0.4) * wave.abs();

      canvas.drawLine(
        Offset(x, centerY - barHeight),
        Offset(x, centerY + barHeight),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) =>
      isActive != oldDelegate.isActive || animation.value != oldDelegate.animation.value;
}