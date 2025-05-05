import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pim_project/Views/AssistantVocalScreens/AssistantService.dart';
import 'package:pim_project/Views/AssistantVocalScreens/FaceRecogService.dart';
import 'package:pim_project/Views/PatientInfoForAssistant/PatientInformations.dart';
import 'package:pim_project/Views/VoiceRecordingPages/VoiceRecordingPage.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:math' as math;

import 'package:shared_preferences/shared_preferences.dart';

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
  final ImagePicker _picker = ImagePicker();
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

  Future<void> _pickImageFromGallery() async {
    final photo = await _picker.pickImage(source: ImageSource.gallery);
    if (photo != null) {
      await _identifyPersonFromPhoto(photo);
    }
  }

  Future<void> _pickImageFromCamera() async {
    final photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      await _identifyPersonFromPhoto(photo);
    }
  }


  Future<void> _identifyPersonFromPhoto(XFile photo) async {
    final recognizer = FaceRecognitionService();
    await recognizer.loadModel();

    final queryEmbedding = await recognizer.getEmbedding(File(photo.path));

    final prefs = await SharedPreferences.getInstance();
    final familyJson = prefs.getString('patient_family') ?? '[]';
    final List<dynamic> familyList = jsonDecode(familyJson);
    final knownEmbeddings = <String, List<double>>{};

    for (var member in familyList) {
      final name = member['name'];
      final path = member['photoPath'];
      if (path != null && File(path).existsSync()) {
        final emb = await recognizer.getEmbedding(File(path));
        knownEmbeddings[name] = emb;
      }
    }

    final match = recognizer.matchEmbedding(queryEmbedding, knownEmbeddings,threshold: 0.5);

    final responseText = match != null
        ? "هذي صورة ${match}"
        : "ما عرفتش شكون هذا في الصورة";

    setState(() {
      conversationHistory.add(Message(
          text: '$responseText [Photo: ${photo.path}]', isUser: false));
    });
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.purple,
        elevation: 0,
        title: const Text(
          'AlzMind Assistant',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
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
                MaterialPageRoute(
                    builder: (context) => const PatientInfoPage()),
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
            Expanded(
              child: conversationHistory.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'Assets/SplashScreen/splash_image.png',
                            width: 100,
                            height: 100,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Hey there! Start chatting with AlzMind!',
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 12),
                      itemCount: conversationHistory.length,
                      itemBuilder: (context, index) {
                        final message = conversationHistory[index];
                        return _buildMessageBubble(
                          message: message.text,
                          isUser: message.isUser,
                          timestamp: message.timestamp,
                        );
                      },
                    ),
            ),
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isListening || isAIResponding
                          ? [Colors.purple, Colors.blue]
                          : [Colors.transparent, Colors.transparent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(36),
                  ),
                  child: CustomPaint(
                    painter: WaveformPainter(
                      animation: _animationController,
                      isActive: isListening || isAIResponding,
                      color: Colors.white,
                    ),
                    child: Center(
                      child: Text(
                        isListening
                            ? 'Listening...'
                            : isAIResponding
                                ? 'Responding...'
                                : 'Ready',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildActionButton(
                        icon: Icons.photo,
                        color: Colors.purple,
                        onPressed: _pickImageFromGallery,
                        tooltip: 'Choose from Gallery',
                        size: 20,
                      ),
                      const SizedBox(width: 16),
                      _buildActionButton(
                        icon: isListening ? Icons.stop : Icons.mic,
                        color: isListening ? Colors.red : Colors.purple,
                        onPressed: _speechService.isSpeechInitialized
                            ? (isListening
                                ? _speechService.stopListening
                                : _speechService.startListening)
                            : null,
                        tooltip:
                            isListening ? 'Stop Listening' : 'Start Listening',
                        size: 38,
                      ),
                      const SizedBox(width: 16),
                      _buildActionButton(
                        icon: Icons.camera_alt,
                        color: Colors.purple,
                        onPressed: _pickImageFromCamera,
                        tooltip: 'Take Photo',
                        size: 20,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback? onPressed,
    required String tooltip,
    required double size,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: color,
        shape: const CircleBorder(),
        elevation: 4,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(30),
          child: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(icon, color: Colors.white, size: size),
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble({
    required String message,
    required bool isUser,
    required DateTime timestamp,
  }) {
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
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75,
          ),
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isUser ? Colors.purple : Colors.white,
            borderRadius: BorderRadius.circular(20).copyWith(
              topLeft:
                  isUser ? const Radius.circular(20) : const Radius.circular(4),
              topRight:
                  isUser ? const Radius.circular(4) : const Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (displayText.isNotEmpty)
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
                    borderRadius: BorderRadius.circular(12),
                    child: photoPath.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: photoPath,
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 150,
                              height: 150,
                              color: Colors.grey[200],
                              child: const Center(
                                  child: CircularProgressIndicator()),
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 150,
                              height: 150,
                              color: Colors.grey[200],
                              child: const Icon(Icons.error, color: Colors.red),
                            ),
                          )
                        : Image.file(
                            File(photoPath),
                            width: 150,
                            height: 150,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                              width: 150,
                              height: 150,
                              color: Colors.grey[200],
                              child: const Icon(Icons.error, color: Colors.red),
                            ),
                          ),
                  ),
                ],
                const SizedBox(height: 4),
                Text(
                  '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}',
                  style: TextStyle(
                    color: isUser ? Colors.white70 : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
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

  WaveformPainter({
    required this.animation,
    required this.isActive,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (!isActive) return;

    final paint = Paint()
      ..color = color.withOpacity(0.9)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const bars = 24;
    final barWidth = size.width / bars;
    final centerY = size.height / 2;

    for (var i = 0; i < bars; i++) {
      final x = i * barWidth;
      final normalized = (i / bars) * 2 * math.pi;
      final wave1 = math.sin(normalized + (animation.value * 4 * math.pi));
      final wave2 = math.cos(normalized + (animation.value * 2 * math.pi));
      final barHeight = (size.height * 0.35) * (wave1.abs() + wave2.abs()) / 2;

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


