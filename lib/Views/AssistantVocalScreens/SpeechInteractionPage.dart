import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'dart:math' as math;

class SpeechInteractionPage extends StatefulWidget {
  @override
  _SpeechInteractionPageState createState() => _SpeechInteractionPageState();
}

class _SpeechInteractionPageState extends State<SpeechInteractionPage>
    with SingleTickerProviderStateMixin {
  bool isListening = false;
  bool isAIResponding = false;
  String userMessage = '';
  String aiResponse = '';

  final SpeechToText _speechToText = SpeechToText();
  bool _speechEnabled = false;

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    if (_speechEnabled) {
      await _speechToText.listen(
        onResult: _onSpeechResult,
        listenFor: Duration(seconds: 30),
        partialResults: true,
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
        localeId: 'ar-TN',
      );
      setState(() {
        isListening = true;
      });
    }
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      isListening = false;
    });
    // Trigger AI response when we have a message
    if (userMessage.isNotEmpty) {
      _handleAIResponse();
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      userMessage = result.recognizedWords;
    });
  }

  void _handleAIResponse() {
    setState(() {
      isAIResponding = true;
    });

    // Simulate AI response - replace with your actual AI logic
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        aiResponse = 'This is a sample AI response to: $userMessage';
        isAIResponding = false;
      });
    });
  }

  Future<void> _toggleListening() async {
    if (_speechToText.isNotListening) {
      _startListening();
    } else {
      _stopListening();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF723D92),
        elevation: 0,
        title: const Text(
          'AI Assistant',
          style: TextStyle(color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 100,
            decoration: const BoxDecoration(
              color: Color(0xFF723D92),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30),
                bottomRight: Radius.circular(30),
              ),
            ),
            child: Center(
              child: Text(
                isListening ? 'Listening...' :
                isAIResponding ? 'AI is responding...' :
                _speechEnabled ? 'Tap the microphone to start' : 'Speech not available',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (userMessage.isNotEmpty)
                  _buildMessageBubble(
                    message: userMessage,
                    isUser: true,
                  ),
                if (aiResponse.isNotEmpty)
                  _buildMessageBubble(
                    message: aiResponse,
                    isUser: false,
                  ),
              ],
            ),
          ),

          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Container(
                height: 100,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: CustomPaint(
                  size: const Size(double.infinity, 100),
                  painter: WaveformPainter(
                    animation: _animationController,
                    isActive: isListening || isAIResponding,
                    color: const Color(0xFF723D92),
                  ),
                ),
              );
            },
          ),

          Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FloatingActionButton(
                  heroTag: 'micButton',
                  backgroundColor: isListening ? Colors.red : const Color(0xFF723D92),
                  onPressed: _speechEnabled ? _toggleListening : null,
                  child: Icon(
                    isListening ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble({required String message, required bool isUser}) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? const Color(0xFF723D92) : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Text(
          message,
          style: TextStyle(
            color: isUser ? Colors.white : Colors.black87,
            fontSize: 16,
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
      ..color = color.withOpacity(0.5)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final width = size.width;
    final height = size.height;
    const bars = 60;
    final barWidth = width / bars;

    for (var i = 0; i < bars; i++) {
      final x = i * barWidth;
      final normalized = (i / bars) * 2 * math.pi;
      final wave = math.sin(normalized + (animation.value * 2 * math.pi));
      final barHeight = (height / 2) * wave.abs();

      canvas.drawLine(
        Offset(x, height / 2 - barHeight / 2),
        Offset(x, height / 2 + barHeight / 2),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) => true;
}