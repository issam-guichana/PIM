import 'package:flutter/material.dart';
import 'package:pim_project/Views/AssistantVocalScreens/AssistantService.dart';
import 'package:pim_project/Views/PatientInfoForAssistant/PatientInformations.dart';
import 'package:pim_project/Views/VoiceRecordingPages/VoiceRecordingPage.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:math' as math;

class Message {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  Message({required this.text, required this.isUser})
      : timestamp = DateTime.now();
}

class SpeechInteractionPage extends StatefulWidget {
  const SpeechInteractionPage({super.key});

  @override
  _SpeechInteractionPageState createState() => _SpeechInteractionPageState();
}

class _SpeechInteractionPageState extends State<SpeechInteractionPage>
    with SingleTickerProviderStateMixin {
  final SpeechService _speechService = SpeechService();
  late AnimationController _animationController;
  final ScrollController _scrollController = ScrollController();
  List<Message> conversationHistory = [];
  bool isListening = false;
  bool isAIResponding = false;
  String userMessage = '';
  String aiResponse = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _speechService.initSpeech(
      onSpeechResult: _onSpeechResult,
      onStatusChange: (listening, responding, userMsg, aiResp, history) {
        setState(() {
          isListening = listening;
          isAIResponding = responding;
          userMessage = userMsg;
          aiResponse = aiResp;
          conversationHistory = history;
          if (isListening || isAIResponding) {
            _animationController.repeat();
          } else {
            _animationController.stop();
          }
        });
        if (history.isNotEmpty && _scrollController.hasClients) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          });
        }
      },
    );
  }

  void _onSpeechResult(String recognizedWords, bool isFinal) {
    setState(() {
      userMessage = recognizedWords.toLowerCase();
    });

    if (recognizedWords.contains("call issam") ||
        recognizedWords.contains("كلم عصام") ||
        recognizedWords.contains("كلم لي ولدي") ||
        recognizedWords.contains("كلم ولدي") ||
        recognizedWords.contains("تكلم عصام")) {
      _speechService.stopListening();
      _speechService.makePhoneCall("+21625786329");
      return;
    }

    if (recognizedWords.contains("ذكرني ناخو الدوا") ||
        recognizedWords.contains("فكرني ناخو الدوا") ||
        recognizedWords.contains("فكرني ناخذ الدواء") ||
        recognizedWords.contains("فكرني ناخذ الدوا")) {
      _speechService.scheduleReminder(
          "خوذ الدوا", DateTime.now().add(const Duration(seconds: 10)));
    }

    if (isFinal) {
      _speechService.stopListening();
    }
  }

  @override
  void dispose() {
    _speechService.dispose();
    _animationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: const Color(0xFF723D92),
        elevation: 0,
        title: const Text(
          'Voice Assistant',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PatientInfoPage()),
              );
            },
            tooltip: 'Enter Patient Information',
          ),
          IconButton(
            icon: const Icon(Icons.mic_external_on, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const VoiceRecordingPage()),
              );
            },
            tooltip: 'Record Voice',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () {
              setState(() {
                conversationHistory.clear();
                userMessage = '';
                aiResponse = '';
              });
              _speechService.clearConversation();
            },
            tooltip: 'Clear Conversation',
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
                gradient: LinearGradient(
                  colors: [
                    Color(0xFF723D92),
                    Color(0xFF9B59B6),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Center(
                child: Text(
                  _speechService.getStatusText(),
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
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.chat_bubble_outline,
                            size: 80, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          'Start the conversation to interact with me',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
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
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
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
                backgroundColor:
                isListening ? Colors.red : const Color(0xFF723D92),
                onPressed: _speechService.isSpeechInitialized
                    ? (isListening
                    ? _speechService.stopListening
                    : _speechService.startListening)
                    : null,
                child: Icon(
                  isListening ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 30,
                ),
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble({required String message, required bool isUser}) {
    String? photoPath;
    String displayText = message;

    if (!isUser && message.contains('[Photo: ')) {
      final parts = message.split('[Photo: ');
      if (parts.length > 1) {
        displayText = parts[0].trim();
        photoPath = parts[1].split(']').first;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Card(
          elevation: 2,
          shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          color: isUser ? const Color(0xFF723D92) : Colors.grey[200],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Text(
                  displayText,
                  style: TextStyle(
                    color: isUser ? Colors.white : Colors.black87,
                    fontSize: 16,
                  ),
                ),
                if (photoPath != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: photoPath.startsWith('http')
                        ? CachedNetworkImage(
                      imageUrl: photoPath,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                      errorWidget: (context, url, error) =>
                      const Icon(Icons.error),
                    )
                        : Image.file(
                      File(photoPath),
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                    ),
                  ),
                ],
              ],
            ),
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

  WaveformPainter(
      {required this.animation, required this.isActive, required this.color});

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
      isActive != oldDelegate.isActive ||
          animation.value != oldDelegate.animation.value;
}